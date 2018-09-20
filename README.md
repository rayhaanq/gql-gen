# gql-gen
A simple script to generate a single schema.graphql from multiple .graphql files

## Usage
1. Place the script file in the root directory where your GraphQL files are located
2. Run the script.

It simply concatenates all the files together into a single schema.graphql file. This should make it easier to modularize your schema using pure GraphQL files.
No need for imports or anything. The script works recursively so any folder structure should work, as long the script is run from the root.
Currently there is no duplication checks so be careful of duplicate types.
