import os

def get_todos(csv_path):
    todos = []
    if not os.path.exists(csv_path):
        return todos
    with open(csv_path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(',', 1)
            if len(parts) == 2 and parts[1].startswith('TODO:'):
                todos.append((parts[0], parts[1]))
    return todos

def main():
    base = os.path.join('assets', 'locales')
    default_lang = 'en-US'
    for lang in os.listdir(base):
        lang_path = os.path.join(base, lang)
        if not os.path.isdir(lang_path) or lang == default_lang or lang.startswith('_'):
            continue
        file = os.path.join(lang_path, 'ui.csv')
        todos = get_todos(file)
        if todos:
            print(f"TODOs in {lang}:")
            for k, v in todos:
                print(f"  [{lang}] {k}: {v}")
    print("Done.")

if __name__ == '__main__':
    main()
