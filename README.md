# LLM Project Analyzer: AI-Assisted Code Development Tool

## Summary

The LLM Project Analyzer is a powerful bash script designed to streamline your workflow when working with AI coding assistants like Claude and ChatGPT. This tool helps you prepare and organize your project information in a format that's easily digestible by Large Language Models (LLMs), enabling more effective collaboration between you and AI tools during your development process.

Key features:

1. **Selective File Inclusion**: Easily specify which files or directories are most relevant to your current task, allowing you to focus the AI's attention on the parts of your project that matter most.

2. **Directory Structure Visualization**: Generate a clear, hierarchical view of your project structure, helping the AI understand the overall organization of your codebase.

3. **Content Aggregation**: Combine the contents of selected files into a single document, making it simple to share relevant code snippets and file contents with the AI assistant.

4. **Customizable Ignore Rules**: Exclude irrelevant files or directories to keep the output focused and manageable.

5. **Size Management**: Control the output size to stay within token limits of various AI platforms.

By using the LLM Project Analyzer, you can efficiently provide context to AI coding assistants, allowing them to offer more accurate and relevant suggestions, explanations, and code improvements. This tool bridges the gap between your local development environment and AI-powered coding assistants, enhancing your productivity and the quality of AI-assisted coding sessions.

Whether you're seeking code reviews, asking for explanations of complex parts of your project, or collaborating with AI to develop new features, the LLM Project Analyzer helps you set the stage for more effective interactions with AI coding tools.

# LLM Project Analyzer - Detailed Instructions

## Example Installation for MacOS or Linux

1. Open your terminal.

2. Navigate to your home directory:
   ```
   cd ~
   ```

3. If you don't already have a `bin` directory in your home folder, create one:
   ```
   mkdir -p ~/bin
   ```

4. Create a new file named `llm_project_analyzer` in the `~/bin` directory:
   ```
   nano ~/bin/llm_project_analyzer
   ```

5. Copy and paste the entire script into this file.

6. Save the file and exit the text editor (in nano, press Ctrl+X, then Y, then Enter).

7. Make the script executable:
   ```
   chmod +x ~/bin/llm_project_analyzer
   ```

8. Add the `~/bin` directory to your PATH if it's not already there. Add the following line to your `~/.bash_profile` or `~/.zshrc` file (depending on which shell you're using):
   ```
   export PATH="$HOME/bin:$PATH"
   ```

9. Reload your shell configuration:
   ```
   source ~/.bash_profile  # or source ~/.zshrc
   ```

## Usage

The basic syntax for using the script is:

```
llm_project_analyzer [options] [directory]
```

If no directory is specified, the script will analyze the current directory.

### Options

- `-o OUTPUT_FILE` : Name of the output file (default: llm_project_analysis.txt)
- `-f FILE_LIST` : Path to a file containing the list of main files to include (default: llm_main_files.txt)
- `-m MAX_SIZE` : Maximum total size in MB (default: unlimited)
- `-d MAX_DEPTH` : Maximum depth for directory traversal (default: unlimited)
- `-s SUBFOLDERS` : Comma-separated list of subfolders to include (default: none)
- `-i IGNORE_FILE` : Path to a file containing additional files/directories to ignore
- `-a` : Include all files in subfolders (use with caution)
- `-h` : Display the help message

## Examples

1. Analyze the current directory with default settings:
   ```
   llm_project_analyzer
   ```

2. Analyze a specific project directory:
   ```
   llm_project_analyzer /path/to/your/project
   ```

3. Include specific subfolders in the analysis:
   ```
   llm_project_analyzer -s src,lib,tests
   ```

4. Set a maximum output size of 5MB:
   ```
   llm_project_analyzer -m 5
   ```

5. Limit directory traversal depth to 3 levels:
   ```
   llm_project_analyzer -d 3
   ```

6. Use a custom ignore file:
   ```
   llm_project_analyzer -i .customignore
   ```

7. Include all files in all subfolders:
   ```
   llm_project_analyzer -a
   ```

8. Combine multiple options:
   ```
   llm_project_analyzer -o project_analysis.txt -f important_files.txt -s src,lib -m 10 -d 3 -i .customignore /path/to/your/project
   ```

## Tips for Effective Use

1. Create an `llm_main_files.txt` in your project root to specify the most important files for analysis.

2. Use the `-s` option to focus on specific subfolders rather than including all files with `-a`.

3. If your project has many files to ignore, create a separate ignore file and use the `-i` option.

4. Start with a small depth (`-d`) and increase it if needed to avoid overwhelming output for large projects.

5. Use the `-m` option to limit the output size if you're planning to use the output with an LLM that has token limits.

Remember, the script will generate a directory structure and include the content of specified files. The output file will be created in the analyzed directory with the name specified by the `-o` option (default is llm_project_analysis.txt).
