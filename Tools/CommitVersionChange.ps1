# Variables for the version number change commit back to GitHub
$ModuleName = $env:BUILD_DEFINITIONNAME
$WorkingPsd1 = ".\Source\" + $ModuleName + ".psd1"
$PesterResultsPath = ".\Results\" + "PesterResults" + ".xml"
$PSCodeHealthReportResultsPath = ".\Results\" + "PSCodeHealthReport" + ".html"
$ReadMeUpdatePath = ".\" + "ReadMe" + ".md"
$FinalPsd1 = ".\" + $ModuleName + "\" + $ModuleName + ".psd1"
$FinalPsm1 = ".\" + $ModuleName + "\" + $ModuleName + ".psm1"

# Git for the version number change commit back to GitHub
git config user.email "matt.collins@node-it.com"
git config user.name "TheMattCollins0"
git add "$WorkingPsd1"
git add "$PesterResultsPath"
git add "$PSCodeHealthReportResultsPath"
git add "$ReadMeUpdatePath"
git add "$FinalPsd1"
git add "$FinalPsm1"
git commit -m "Updated Version Number ***NO_CI***"
git push origin HEAD:master
