---
layout: post
title: Returning large data iteratively in dotnet core.
image: /assets/img/yielding-large-results/cover.png
readtime: 5 minutes
---

### Scenario

We have an export function, which pulls data from elasticsearch, and uses graphql to load relational data into the data. It returns a very large dataset.

The problem with this, is we run small containers, and don't want to consume a large amount of memory when working with for example an export, we also don't want the user to wait until the query has completed, before the data can be returned.

The result of the method we have, can return sometimes 2000000 rows of CSV data, and this can take over 30 seconds when working with some of the larger datasets, before the Download box appears.

<amp-img src="/assets/img/yielding-large-results/download.png"
  width="4096"
  height="2304"
  layout="responsive">
</amp-img>

From what I found online, there aren't many resources out there where this has been solved.

The built in functionality for streaming content, using the FileStream works well for File, but not so much so if you are returning data in an iterable format, as it would try and load all the data into memory, before returning the response.

I considered writing the result to file and handling the response using the file stream functionality, but I still had the issue where it took a considerable amount of time before the download started.

I managed to get around this by working directly with the Response using chunked encoding.

This allows to return data in chunks, and when combined with a yield return from my data source, I am able to send back say 1000 rows at a time.

From the client side, rather than a very lengthy wait for the data to start downloading, now the download starts quickly, but gives the user the ability to see the data being downloaded, which to them seems like a slow download, but much better than waiting forever for the download to start.

<amp-img src="/assets/img/yielding-large-results/download2.png"
  width="1180"
  height="664"
  layout="responsive">
</amp-img>


Here are some examples of how I did this:


Example of the controller method

```
[HttpGet]
[SwaggerResponse(HttpStatusCode.OK, typeof(ExportDataByMonth))]
[ResponseCache(VaryByHeader = "User-Agent", Duration = 30)]
public void ExportByFiltered(int month, int year)
{
    try
    {
        Response.ContentLength = null;
        Response.StatusCode = 200;
        Response.ContentType = "text/plain";
        Response.Headers["Content-Disposition"] = $"attachment; filename=\"export-by-filtered-{year}-{month}.csv\"";
        
        using(var streamWriter = new StreamWriter(Response.Body))
        using (var csvStream = new CsvWriter(streamWriter))
        {
            var exportData = _graphQlRepository.GetFilteredExport(userId.Value, month, year);
            if (!exportData.Any())
                csvStream.WriteRecords(new[] {new {message = "No data was found during this period."}});
            else
            {
                foreach (IEnumerable<object> value in exportData)
                {
                    csvStream.WriteRecords(value);
                    Response.Body.Flush();
                }
            }

            streamWriter.Flush();
            csvStream.Flush();
            Response.Body.Flush();
        }
    }
    catch (Exception e)
    {
        _logger.Error(e);
        throw;
    }
}
```

Example of returning the data using yield

```
public IEnumerable<object> GetFilteredExport(long userId, int month, int year)
{
    var next = 0;
    const int size = 1000;
    while (true)
    {
        var query = GraphQLExportQueries.GetDataByFiltered(userId, month, year, next, size);
        var response = Query(query);
        var mappedResults = _getExportDataMapper.MapMonthData(response);

        if (!mappedResults.Any())
            break;

        next += size;
        yield return mappedResults;
    }
}
```

