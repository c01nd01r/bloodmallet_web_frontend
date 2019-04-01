Write-Host "Start deploy process in 5..."

Start-Sleep -s 5

# Save start location
$start_location = pwd

Write-Host "Starting virtual environment" -NoNewline
# Activate virtual env
env/Scripts/activate
Write-Host "    Done" -ForegroundColor Green

# Navigate to necessary subdirectory (which has the actual app for the appengine)
cd bloodmallet/

Write-Host "Preparing translations" -NoNewline
# collect and compile translateable texts
$languages = @('cn', 'de', 'es', 'fr', 'it', 'ko', 'pt', 'ru')
foreach($language in $languages) {
    python manage.py makemessages --locale=$language >$null
    python manage.py compilemessages --locale=$language >$null
}
Write-Host "          Done" -ForegroundColor Green

Write-Host "Preparing Styles" -NoNewline
# Create fresh css files
python manage.py compilescss >$null
Write-Host "                Done" -ForegroundColor Green


Write-Host "Preparing static files" -NoNewline
# Collect fresh css files
python manage.py collectstatic --clear --noinput --ignore=*.scss --ignore=*.po >$null
Write-Host "          Done" -ForegroundColor Green

# Deploy
gcloud app deploy --quiet

Write-Host "Cleaning up" -NoNewline
# remove compiled css files
python manage.py compilescss --delete-files

# Delete created "static" directory
rm -r -Force .\static\ >$null

# Deactivate virtual env
deactivate

# Return to start of script location
cd $start_location
Write-Host "                     Done" -ForegroundColor Green
Write-Host "------------------------------------"
Write-Host "Deployment successful"
