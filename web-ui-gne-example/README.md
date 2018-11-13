# How to create a custom UI

You can either check the commit who created this folder or follow the instructions.

## How to

### Create basic structure

 * Copy folder web-ui-gne-example on the same path but with the name you want for your UI, like web-ui-gne-$name.

 * Add the UI on web/pom.xml

Look for the string "example" on the maven-war-plugin section and add the lines with corresponds to your $name UI.

 * Add the UI on web-ui/src/main/resources/WEB-INF/classes/web-ui-wro-sources.xml

Look for the string "example" and add the two lines with corresponds to your $name UI.

 * Change name of web-ui-gne-$name/src/main/resources/catalog/views/example to $name
 
 * Change the name of the files in web-ui-gne-$name/src/main/resources/catalog/views/example with $name
 
 * Remove the file web-ui-gne-$name/src/main/resources/catalog/js/GnLocale.js to prevent overriding.
 
 * Remove the file web-ui-gne-$name/src/main/resources/catalog/views/templates/index.html to prevent overriding.
 
Now you can run GeoNetwork as normal and it will have the new UI ready to use.

Suggestion: start with the index.html file on the templates.

## TODO

 * Activate UI with profile so not all UIs are added to the war. This will also help with overriding. Right now no wildcards are accepted on the resources list.