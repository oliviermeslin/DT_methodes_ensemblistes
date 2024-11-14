# Define the YAML file
yaml_file="_quarto.yml"

# Extract the list of qmd files under `render` and concatenate them
qmd_files=$(grep -A 20 "render:" "$yaml_file" | grep -E "\.qmd$" | sed 's/^\s*-\s*//')

echo "$qmd_files"

# Concatenate the qmd files into one file and add the Quarto header for Typst output 
output_file="dt_methodes_ensemblistes.qmd"
cat header_typst_output.yml $qmd_files > "$output_file"

echo "Concatenated files into $output_file"

# Compile the Typst output
quarto render dt_methodes_ensemblistes.qmd --verbose --to typst --output dt_methodes_ensemblistes.pdf

# Put the PDF output on the website
mv dt_methodes_ensemblistes.pdf _site/dt_methodes_ensemblistes.pdf

# Clean the repo
rm dt_methodes_ensemblistes.qmd