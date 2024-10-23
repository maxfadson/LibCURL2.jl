using Pkg
using Clang.Generators
using Clang.Generators.JLLEnvs
using LibCURL2_jll

cd(@__DIR__)

# Указываем путь к папке с вашими заголовочными файлами
include_dir = "/Users/fadson/work/wedojuci2/curl-8.9.1/include/curl"  # Здесь укажите путь к вашей папке с заголовками
curl_h = joinpath(include_dir, "curl.h")
@assert isfile(curl_h)  # Проверка, что файл существует

# Путь к папке для сгенерированных файлов
output_dir = joinpath(@__DIR__, "..", "lib")
mkpath(output_dir)  # Создание директории, если она не существует

# Опционально: если у вас есть другие файлы, например mprintf.h, вы можете их также указать
# mprintf_h = joinpath(include_dir, "mprintf.h")
# stdcheaders_h = joinpath(include_dir, "stdcheaders.h")

# Загрузка опций из файла generator.toml
options = load_options(joinpath(@__DIR__, "generator.toml"))

# Цикл по целевым архитектурам
for target in JLLEnvs.JLL_ENV_TRIPLES
    @info "processing $target"

    # Указание пути для выходного файла
    options["general"]["output_file_path"] = joinpath(@__DIR__, "..", "lib", "$target.jl")

    # Получаем аргументы для целевой архитектуры
    args = get_default_args(target)
    push!(args, "-I$include_dir")  # Указываем путь к папке с заголовочными файлами
    push!(args, "-D__STDC__=0", "-DCURL_DISABLE_TYPECHECK")  # Отключаем проверки типов

    # Указываем заголовочные файлы
    header_files = [curl_h]

    # Создание контекста для генерации
    ctx = create_context(header_files, args, options)

    # Запуск генерации
    build!(ctx)
end