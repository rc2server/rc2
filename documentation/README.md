# Documentation

## Compute JSON Schema

The file `compute-to.schema.json` contains the schema of commands accepted by the compute engine. The directory `toTestData` contains tests to validate this schema is correct.

Steps to prepare for performing validation:

1. Install [nodenv](https://github.com/nodenv/nodenv)
1. Install a npm runtime `nodeenv install 12.8,.0`
1. Run `eval "$(nodenv init -)"` and then add that to your `.bash_profile`.
1. `nodenv rehash`
1. Install ajv: `npm install -g ajv`
1. `nodenv rehash`

Test validations: `ajv -s compute-to.schema.json -d toTestData/*.json`

### Client API

File `clientAPI.md`. Not sure of accuracy.

### Variable JSON Format

file `variableFormat.md`. Not sure of accuracy.

