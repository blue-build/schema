import { pascalCase } from "change-case";
import fs from "node:fs"

const modulesDir = "./src-tsp/modules"

const res = await fetch("https://blue-build.org/modules.json")
const modules = await res.json()

let moduleImports = []
let moduleModels = []

fs.existsSync(modulesDir) && fs.rmSync(modulesDir, { recursive: true });
fs.mkdirSync(modulesDir)

for (const module of modules) {
    if (module.tsp === "") continue
    const res = await fetch(module.tsp)
    let text = await res.text()
    let last_line = ''

    text = text // add `...ModuleDefaults;` after the model type
        .split("\n")
        .flatMap(line => {
            if (line.trimStart().startsWith("model")) {
                if (last_line.includes("@jsonSchema")) {
                    moduleModels.push(line.split(' ')[1]);
                }
                last_line = line
                return [
                    `@extension("additionalProperties", false)`,
                    line
                ];
            }
            if (line.trimStart().startsWith(`type: "${module.name}`)) {
                last_line = line
                return [
                    line,
                    '',
                    '    ...ModuleDefaults; // added by fetchModuleSchemas.js',
                ];
            } else {
                last_line = line
                return line;
            }
        })
        .join('\n')

    fs.writeFileSync(`${modulesDir}/${module.name}.tsp`, text)

    moduleImports.push(`${module.name}.tsp`)
}

fs.writeFileSync(`${modulesDir}/index.tsp`, 
moduleImports.map(m => `import "./${m}";`).join("\n") + `

union RepoModule {
${moduleModels.map(m => `  ${m}`).join(",\n")}
}`
)
