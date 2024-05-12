import "@typespec/json-schema";
using TypeSpec.JsonSchema;

alias module = rpmOstreeModule | fontsModule;

@jsonSchema()
model rpmOstreeModule {
    type: "rpm-ostree",
    repos: Array<string>,
    install: Array<string>,
    remove: Array<string>,
}

@jsonSchema()
model fontsModule {
    type: "fonts",
    fonts: {
        "nerd-fonts": Array<string>,
        "google-fonts": Array<string>
    }
}