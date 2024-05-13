# Schema

TypeSpec schema for BlueBuild.

## Versioning

The recipe model uses a crude versioning scheme:_
- The baseUri and filename of the recipe schema is `recipe-vX.json`
- `X` is be the number of the version of the recipe format the model represents, starting at `1`.
    - When a breaking change is made, the number shall be incremented by one. The old version should also be kept, with the previous version number, and in a separate file and model. 
    - This number may be used to select which version of the standard to process in [blue-build/cli](https://github.com/blue-build/cli/)