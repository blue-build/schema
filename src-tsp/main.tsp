import "@typespec/json-schema";
import "./modules.tsp";

using TypeSpec.JsonSchema;

@jsonSchema("recipe-v1.json")
model Recipe {
    name: string,
    description: string,
    "base-image": string,
    "image-version": string,
    modules: Array<Module>
}