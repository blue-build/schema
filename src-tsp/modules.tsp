import "@typespec/json-schema";
using TypeSpec.JsonSchema;

alias module = rpmOstreeModule | fontsModule;

@jsonSchema("/modules/rpm-ostree.json")
model rpmOstreeModule {
    type: "rpm-ostree",
    repos: Array<string>,
    install: Array<string>,
    remove: Array<string>,
}

@jsonSchema("/modules/fonts.json")
model fontsModule {
    type: "fonts",
    fonts: {
        "nerd-fonts": Array<string>,
        "google-fonts": Array<string>
    }
}