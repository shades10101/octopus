# This script creates library set variables from a text file.
# Contents of the text file should be exactly like this (with Variable_name, Variable_value included  at the top of the file):
#
# Variable_name, Variable_value
# hostname, blue
# memory, 15Gi
#
# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Run this first:
# Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies

Add-Type -Path 'Octopus.Client.dll'

# Octopus connection info, make API key in your profile
$apikey = '' # Get this from your profile
$octopusURI = 'https://octopus.acuityads.cloud/api/'

# Create endpoint and client
$endpoint = New-Object Octopus.Client.OctopusServerEndpoint($octopusURI, $apikey)
$client = New-Object Octopus.Client.OctopusClient($endpoint)

# Get default repository and get space by name
$repository = $client.ForSystem()
$space = $repository.Spaces.FindByName("illumin")

# Get space specific repository and get all projects in space
$repositoryForSpace = $client.ForSpace($space)
$projects = $repositoryForSpace.Projects.GetAll()

# For each loop to create library set. 
Import-CSV "~\variables.txt" | %{
  $libraryVariableSetId = "" # Get this from /api/libraryvariablesets
  $variableName = $_."Variable_name" # Name of the new variable
  $variableValue = $_."Variable_value" # Value of the new variable
  $libraryVariableSet = $repositoryForSpace.LibraryVariableSets.Get($libraryVariableSetId);
  $variables = $repositoryForSpace.VariableSets.Get($libraryVariableSet.VariableSetId);
  $myNewVariable = new-object Octopus.Client.Model.VariableResource
  $myNewVariable.Name = $variableName
  $myNewVariable.Value = $variableValue
  $variables.Variables.Add($myNewVariable)
  $repository.VariableSets.Modify($variables)
}
