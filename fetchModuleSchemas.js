import { parse } from 'yaml'
import { pascalCase } from "change-case";
import fs from "node:fs"

const modulesDir = "./src-tsp/modules"

const res = await fetch("https://raw.githubusercontent.com/blue-build/modules/main/modules.json")
const modules = await res.json()

let moduleImports = []
let moduleModels = []

fs.existsSync(modulesDir) && fs.rmSync(modulesDir, { recursive: true });
fs.mkdirSync(modulesDir)

for (const module of modules) {
    const res = await fetch(module)
    const moduleYml = parse(await res.text())
    if (moduleYml.typespec) {
        const res = await fetch(moduleYml.typespec)
        let text = await res.text()

        text = text // add `...ModuleDefaults;` after the model type
            .split("\n")
            .flatMap(line => {
                if (line.trimStart().startsWith(`type: "${moduleYml.name}"`)) {
                    return [
                        line,
                        '',
                        '    ...ModuleDefaults; // added by fetchModuleSchemas.js',
                    ]
                } else {
                    return line;
                }
            })
            .join('\n')

        fs.writeFileSync(`${modulesDir}/${moduleYml.name}.tsp`, text)

        moduleImports.push(`${moduleYml.name}.tsp`)
        moduleModels.push(`${pascalCase(moduleYml.name)}`)
    }
}

fs.writeFileSync(`${modulesDir}/index.tsp`, 
moduleImports.map(m => `import "./${m}";`).join("\n") + `
alias RepoModule = ${moduleModels.map(m => `${m}Module`).join(" | ")};`
)