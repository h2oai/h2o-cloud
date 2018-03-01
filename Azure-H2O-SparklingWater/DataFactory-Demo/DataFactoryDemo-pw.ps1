$resourceGroupName = "hdi-dev"
$dataFactoryName = "Jorge-DataFactory"
$pipelineName = "MySparkOnDemandPipeline" # Name of the pipeline

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "92429150-401a-431f-8955-e69c0c119e68"

$df = Get-AzureRmDataFactoryV2 -Name $dataFactoryName -ResourceGroupName 'datafactory-rg'

$df

Set-AzureRmDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName 'datafactory-rg' -Name "MyStorageLinkedService" -File "MyStorageLinkedService.json"
Set-AzureRmDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName 'datafactory-rg' -Name "MyOnDemandSparkLinkedService" -File "MyOnDemandSparkLinkedService.json"
Set-AzureRmDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName 'datafactory-rg' -Name $pipelineName -File "MySparkOnDemandPipeline.json"

$runId = Invoke-AzureRmDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName 'datafactory-rg' -PipelineName $pipelineName

while ($True) {
    $result = Get-AzureRmDataFactoryV2ActivityRun -DataFactoryName $dataFactoryName -ResourceGroupName 'datafactory-rg' -PipelineRunId $runId -RunStartedAfter (Get-Date).AddMinutes(-30) -RunStartedBefore (Get-Date).AddMinutes(30)

    if(!$result) {
        Write-Host "Waiting for pipeline to start..." -foregroundcolor "Yellow"
    }
    elseif (($result | Where-Object { $_.Status -eq "InProgress" } | Measure-Object).count -ne 0) {
        Write-Host "Pipeline run status: In Progress" -foregroundcolor "Yellow"
    }
    else {
        Write-Host "Pipeline '"$pipelineName"' run finished. Result:" -foregroundcolor "Yellow"
        $result
        break
    }
    ($result | Format-List | Out-String)
    Start-Sleep -Seconds 15
}

Write-Host "Activity `Output` section:" -foregroundcolor "Yellow"
$result.Output -join "`r`n"

Write-Host "Activity `Error` section:" -foregroundcolor "Yellow"
$result.Error -join "`r`n"