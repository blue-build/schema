import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/fonts.json")
model fontsModule {
    type: "fonts",
    fonts: {
        "nerd-fonts": Array<string>,
        "google-fonts": Array<string>
    }
}