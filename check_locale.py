import os
import csv

def get_keys(csv_path):
    keys = set()
    if not os.path.exists(csv_path):
        print(f"File not found: {csv_path}")
        return keys
    with open(csv_path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(',')
            if parts:
                keys.add(parts[0])
    return keys

def main():
    base = os.path.join('assets', 'locales')
    default_lang = 'en-US'
    default_file = os.path.join(base, default_lang, 'ui.csv')
    default_keys = get_keys(default_file)
    print(f"Default ({default_lang}) keys: {len(default_keys)}")
    for lang in os.listdir(base):
        lang_path = os.path.join(base, lang)
        if not os.path.isdir(lang_path) or lang == default_lang or lang.startswith('_'):
            continue
        file = os.path.join(lang_path, 'ui.csv')
        keys = get_keys(file)
        missing = [k for k in default_keys if k not in keys]
        if missing:
            print(f"Missing keys in {lang}:")
            for k in missing:
                print(f"  [{lang}] {k}")
        else:
            print(f"All keys present in {lang}.")
    print("Done.")

if __name__ == '__main__':
    main()
