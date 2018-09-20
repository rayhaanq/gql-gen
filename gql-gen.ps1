#Cat "$($PSScriptRoot)*.graphql" | sc schema.graphql

$SchemaFile = "$($PSScriptRoot)/schema.graphql"
if (Test-Path $SchemaFile) 
{
  Remove-Item $SchemaFile
  Write-Host "Removed old schema file"
}

$mutations = ""
$queries = ""
$subscriptions = ""
$types = ""
$inputs = ""

Get-ChildItem -Recurse $PSScriptRoot -Filter *.graphql | 
Foreach-Object {
    $content = Get-Content $_.FullName
    Write-Host "Apending $($_.Name)..."
    ForEach($line in $content) {
        if($line -Match "type Query"){
            $currentLineIndex = $content.IndexOf($line)

            while (1 -ne 2) {
                $currentLineIndex = $currentLineIndex + 1
                $nextLine = $content[$currentLineIndex]

                if ($nextLine -Match "}") {break}

                $queries = "$($queries)$($nextLine)`r`n"
            }
        } elseif($line -Match "type Mutation"){
            $currentLineIndex = $content.IndexOf($line)

            while (1 -ne 2) {
                $currentLineIndex = $currentLineIndex + 1
                $nextLine = $content[$currentLineIndex]

                if ($nextLine -Match "}") {break}

                $mutations = "$($mutations)$($nextLine)`r`n"
            }
        } elseif($line -Match "type Subscription"){
            $currentLineIndex = $content.IndexOf($line)

            while (1 -ne 2) {
                $currentLineIndex = $currentLineIndex + 1
                $nextLine = $content[$currentLineIndex]

                if ($nextLine -Match "}") {break}

                $subscriptions = "$($subscriptions)$($nextLine)`r`n"
            }
        } elseif ($line -Match "type "){
            $currentLineIndex = $content.IndexOf($line)
            
            $types = $types + $line + "`r`n"
            while (1 -ne 2) {
                $nextLine = $content[$currentLineIndex + 1]
                $types = "$($types)$($nextLine)`r`n"
                $currentLineIndex = $currentLineIndex + 1
                
                if ($nextLine -Match "}") {
                    $types = $types + "`r`n"
                    break
                }
            }
        } elseif ($line -Match "input "){
            $currentLineIndex = $content.IndexOf($line)
            
            $inputs = $inputs + $line + "`r`n"
            while (1 -ne 2) {
                $nextLine = $content[$currentLineIndex + 1]
                $inputs = "$($inputs)$($nextLine)`r`n"
                $currentLineIndex = $currentLineIndex + 1
                
                if ($nextLine -Match "}") {
                    $inputs = $inputs + "`r`n"
                    break
                }
            }
        }
    }
}

$mutationsOutput = "type Mutation {`r`n$($mutations)`r`n}`r`n`r`n"
$queriesOutput = "type Query {`r`n$($queries)`r`n}`r`n`r`n"
$subsOutput = "type Subscription {`r`n$($subscriptions)`r`n}`r`n`r`n"
$typesOutput = "$($types)"
$inputsOutput = "$($inputs)"
$schemaOutput = "schema {`r`n`tquery: Query`r`n`tmutation: Mutation`r`n`tsubscription:Subscription`r`n}"

$output = $queriesOutput + $mutationsOutput + $subsOutput + $typesOutput + $inputsOutput + $schemaOutput

#Write-Host $output

#filter and save content to the original file
#$content | Where-Object {$_ -match 'step[49]'} | Set-Content $_.FullName

#filter and save content to a new file 
$output | Out-File -Append "$($PSScriptRoot)/schema.graphql"
Write-Host "Successfully generated schema.graphql"