# Segger Build Action

This is a custom GitHub Action built with Docker that uses Segger Embedded Studio tools for building projects.

## Inputs

| Name          | Description                                                                 | Default | Required |
|---------------|-----------------------------------------------------------------------------|---------|----------|
| `config`      | Build configuration (e.g., `Debug`, `Release`)                             |         | Yes      |
| `D`           | Define macros with optional values (e.g., `DEVICE_MODE_CLIENT,ANOTHER_MACRO`) |         | No       |
| `property`    | Set project properties (e.g., `NAME=value,DEBUG=true`)                     |         | No       |
| `projectName` | Name of the project folder                                                 |         | Yes      |
| `projectPath` | Path to the project within the project folder                              |         | Yes      |
| `projectFile` | Name of the project file to build                                          |         | Yes      |
| `seggerVersion` | Segger IDE version used to build                                          | `5.40`  | No       |

## Example Usage

Assumptions:   
- repo name is `projectName`
- you have the next file structure in your repo:
```
.
├── README.md
├── main.c
├── ...
├── my
│   ├── config
│   │   └── ...
│   └── emprjPath
│       ├── flash_placement.xml
│       └── my_project_file.emProject
├── ...
```

```yaml
      - name: Run Segger Action
        uses: ./  # Uses the action from the current repository
        with:
          config: Release
          D: "DEVICE_MODE_CLIENT,ANOTHER_MACRO=VALUE"
          property: "NAME=value,DEBUG=true"
          projectName: "projectName" # actually, repo name, because there can be multiple projects 
          projectPath: "my/emprjPath" # relative under projectName
          projectFile: "my_project_file.emProject"
          seggerVersion: "5.40" # default and the only one for now
```
