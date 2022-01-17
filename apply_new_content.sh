admin_mail_address="sphinx_admin@nitrokey.com"

echo "$(date) [apply_new_content.sh] Content change triggered." >> /var/www/sphinx/logs_sphinx/webhook.log

echo -n "$(date) [apply_new_content.sh] Pulling Repo..." >> /var/www/sphinx/logs_sphinx/webhook.log

cd /var/www/sphinx/sphinx/nitrokey-documentation

# pull new content
git pull

if [ $? -eq 0 ]
then
	echo "DONE" >> /var/www/sphinx/logs_sphinx/webhook.log
else
	echo "FAILED" >> /var/www/sphinx/logs_sphinx/webhook.log
	echo "Building Docs.nitrokey.com – pulling repo FAILED." | mail -s "[Sphinx] Pulling Repo FAILED." $admin_mail_address

fi


# build english version
echo -n "$(date) [apply_new_content.sh] Building englisch Versions..." >> /var/www/sphinx/logs_sphinx/webhook.log

sphinx-build -a -D language='en' -b html . /var/www/sphinx/www/docs.nitrokey.com_en_temp

if [ $? -eq 0 ]
then
	echo "DONE" >> /var/www/sphinx/logs_sphinx/webhook.log
	mv /var/www/sphinx/www/static/?? /var/www/sphinx/www/docs.nitrokey.com_en_temp/
	rm /var/www/sphinx/www/static -r
	mv /var/www/sphinx/www/docs.nitrokey.com_en_temp /var/www/sphinx/www/static
else
	echo echo "FAILED" >> /var/www/sphinx/logs_sphinx/webhook.log
	echo "Building Docs.nitrokey.com Language EN FAILED. " | mail -s "[Sphinx] Building Language EN FAILED." $admin_mail_address
fi


echo -n "$(date) [apply_new_content.sh] Building /locales/ ..." >> /var/www/sphinx/logs_sphinx/webhook.log

# generate language files and push
sphinx-build -b gettext . ./locales/
sphinx-intl update -p ./locales/ -l de -l fr -l es -l nl -l it -l ja -l ru -l zh_CN -l el -l bg -l da -l et -l fi -l lv -l lt -l pl -l pt -l ro -l sv -l sk -l sl -l cs -l hu
if [ $? -eq 0 ]
then
	echo "DONE" >> /var/www/sphinx/logs_sphinx/webhook.log
else
	echo "FAILED" >> /var/www/sphinx/logs_sphinx/webhook.log
	echo "Building  /locales/ FAILED." | mail -s "[Sphinx] Building Locales FAILED." $admin_mail_address

fi

echo "$(date) [apply_new_content.sh] Pushing upstream ..." >> /var/www/sphinx/logs_sphinx/webhook.log

git add --all
git commit -m "Language Files generated by Sphinx"
git push

echo "$(date) [apply_new_content.sh] Pushing upstream ...DONE" >> /var/www/sphinx/logs_sphinx/webhook.log

sleep 60

echo "$(date) [apply_new_content.sh] Trigger deepl translation..." >> /var/www/sphinx/logs_sphinx/webhook.log
bash trigger_deepl.sh wlu_yNzMepL4jsShmM6o9sW3Xa53NWYIOVbxCjBP >> /var/www/sphinx/logs_sphinx/trigger_deepl.log
echo "$(date) [apply_new_content.sh] Trigger deepl translation...done" >> /var/www/sphinx/logs_sphinx/webhook.log

