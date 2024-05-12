import "@typespec/json-schema";
import "./modules.tsp";

using TypeSpec.JsonSchema;

@jsonSchema()
model recipe {
    name: string,
    description: string,
    "base-image": string,
    "image-version": string,
    modules: Array<module>
}