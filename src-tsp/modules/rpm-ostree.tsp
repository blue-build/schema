import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/rpm-ostree.json")
model rpmOstreeModule {
    type: "rpm-ostree",
    repos: Array<string>,
    install: Array<string>,
    remove: Array<string>,
}