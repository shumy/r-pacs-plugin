# r-pacs-plugin
R-PACS is a [Dicoogle](https://github.com/bioinformatics-ua/dicoogle) plugin that has a semi-structured model, composed by the DICOM structure and the extension model to DICOM instances. It was primarily designed for the project of Diabetic Retinopathy Screening, but can be used on any context where a set of annotations are applied to DICOM images.

## Model
OR-Model source is at package pt.ua.ieeta.rpacs.model, and can be represented by the Class Diagram: ![alt text](./docs/r-pacs-model.png)

## Project Build
Build requirements:
* Java version >= 8
* Maven version >= 3.3

In the project folder just fire maven install:
```bash
mvn install
```

## Service Requirements
R-PACS plugin requires the availability of the following software services:
* PostgreSQL >= 9.5
* ElasticSearch => 5.4

To install the DB schema run the script db-create-all.sql available at the ./postgresql folder, and all the database evolutions in the correct order, available at ./postgresql/evolutions folder.

## Plugin Settings
R-PACS is installed as any other Dicoogle plugin, copy it to the Plugin folder and set the settings in the ./settings/r-pacs.xml file:
```xml
<configuration>
  <docUrl><elastic-search service url></docUrl>
  <dbUrl><jdbc config></dbUrl>
  <driver>org.postgresql.Driver</driver>
  <username><postgresql db username></username>
  <password>postgresql db password</password>
</configuration>
```

Example pointing to local instalations of PostgreSQL and ElasticSearch:
```xml
<configuration>
  <docUrl>http://127.0.0.1:9200</docUrl>
  <dbUrl>jdbc:postgresql:db-name</dbUrl>
  <driver>org.postgresql.Driver</driver>
  <username>user</username>
  <password>password</password>
</configuration>
```

