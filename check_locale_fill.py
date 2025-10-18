import os

def get_key_value(csv_path):
    kv = {}
    if not os.path.exists(csv_path):
        return kv
    with open(csv_path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(',', 1)
            if len(parts) == 2:
                kv[parts[0]] = parts[1]
            elif len(parts) == 1:
                kv[parts[0]] = ''
    return kv

def append_todos(csv_path, todos):
    with open(csv_path, 'a', encoding='utf-8') as f:
        for key, value in todos.items():
            f.write(f"{key},TODO: {value}\n")

def main():
    base = os.path.join('assets', 'locales')
    default_lang = 'en-US'
    default_file = os.path.join(base, default_lang, 'ui.csv')
    default_kv = get_key_value(default_file)
    for lang in os.listdir(base):
        lang_path = os.path.join(base, lang)
        if not os.path.isdir(lang_path) or lang == default_lang or lang.startswith('_'):
            continue
        file = os.path.join(lang_path, 'ui.csv')
        kv = get_key_value(file)
        missing = {k: v for k, v in default_kv.items() if k not in kv}
        if missing:
            print(f"Adding TODOs to {lang}:")
            append_todos(file, missing)
            for k, v in missing.items():
                print(f"  [{lang}] {k} -> TODO: {v}")
        # List all TODOs in the file
        todos = [(k, v) for k, v in get_key_value(file).items() if v.startswith('TODO:')]
        if todos:
            print(f"TODOs in {lang}:")
            for k, v in todos:
                print(f"  [{lang}] {k}: {v}")
    print("Done.")

if __name__ == '__main__':
    main()
