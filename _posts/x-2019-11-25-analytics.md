

AWS Glue Built in Transformations

### Dynamic Frames
Dynamic frames contain your data, and you reference its schema to process your data.

### Some of the built in data transformations

| Transformation | Description |
|-|-|
| ApplyMapping | Maps source column and data type to target.|
| Drop Fields | Removes a field |
| DropNullFields| Removes Null Fields |
| Filter | Applies a filter to a frame |
| Join | Joins two fields in a frame |
| Map | Applies a function to a frame |
| MapToCollection | Transforms a frame into a collection |
| Relationize | Converts frame into columnar data and rows |
| RenameField | Renames a field in a frame |
| SelectFields| Selects fields to keep |
| SelectFromCollection | Selects a field to keep from a collection |
| SplitFields| Splits field into two fields |
| SplitRows| Splits a frame into multiple rows |
| Unbox| Unboxes a field |

AWS Glue will auto generate an ETL script, based on the built in data transformations above.
You can edit the script to make changes, and tailor the ETL job to how you want it to run.

One of the most interesting of these auto transformations is Relationize.
It is able to convert a semi structured schema, such as hierarchical JSON, into relational schema


```
{
    "Store": "MyStore",
    "Location": {
        "Country": "United Kingdom",
        "Postcode": "SK22"
    },
    "Ages": [1,2]
}
```

Would be translated to something like:

```
Store, Location-Country, Location-PostCode, AgesId
MyStore, United Kingdom, SK22, 1
MyStore, United Kingdom, SK22, 2

AgesId, Offset, Value
1, 0, 1
2, 1, 2
```





































