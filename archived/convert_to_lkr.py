"""Convert all currency displays from USD ($) to LKR (Sri Lankan Rupees)"""
import os
import re

def replace_currency_in_file(filepath):
    """Replace $ with LKR in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Replace ${{ with LKR {{
        content = content.replace('${{',' LKR {{')
        
        # Replace f"${ with f"LKR {
        content = content.replace('f"${', 'f"LKR {')
        
        # Replace '$' + in JavaScript
        content = content.replace("'$' +", "'LKR ' +")
        content = content.replace("'$'", "'LKR '")
        content = content.replace('"$"', '"LKR "')
        
        # Replace input group text $ with LKR
        content = re.sub(r'<span class="input-group-text">\$</span>', 
                        '<span class="input-group-text">LKR</span>', content)
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ Updated: {filepath}")
            return True
        else:
            print(f"- No changes: {filepath}")
            return False
    except Exception as e:
        print(f"✗ Error in {filepath}: {e}")
        return False

def main():
    print("=" * 60)
    print("Converting Currency from USD ($) to LKR")
    print("=" * 60)
    
    # Files to update
    template_files = [
        'templates/dashboard.html',
        'templates/expenses.html',
        'templates/income.html',
        'templates/budgets.html',
        'templates/goals.html',
        'templates/reports.html',
        'templates/report_monthly_expenditure.html',
        'templates/report_budget_adherence.html',
        'templates/report_savings_progress.html',
        'templates/report_category_distribution.html',
        'templates/report_savings_forecast.html',
    ]
    
    python_files = [
        'app.py',
    ]
    
    updated_count = 0
    
    print("\nUpdating HTML templates...")
    for file in template_files:
        if os.path.exists(file):
            if replace_currency_in_file(file):
                updated_count += 1
        else:
            print(f"✗ File not found: {file}")
    
    print("\nUpdating Python files...")
    for file in python_files:
        if os.path.exists(file):
            if replace_currency_in_file(file):
                updated_count += 1
        else:
            print(f"✗ File not found: {file}")
    
    print("\n" + "=" * 60)
    print(f"Conversion Complete! Updated {updated_count} files")
    print("=" * 60)

if __name__ == "__main__":
    main()
