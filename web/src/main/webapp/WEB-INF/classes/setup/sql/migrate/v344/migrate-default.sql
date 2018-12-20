UPDATE Settings set value = 'http://www.openbasiskaart.nl/mapcache/%3FLAYERS=osm-nb%26SERVICE=WMS%26VERSION=1.1.1%26REQUEST=GetMap%26STYLES=%26FORMAT=image%2Fpng%26EXCEPTIONS=application%2Fvnd.ogc.se_inimage%26SRS={SRS}%26BBOX={MINX},{MINY},{MAXX},{MAXY}%26WIDTH={WIDTH}%26HEIGHT={HEIGHT}' WHERE name = 'region/getmap/background';

UPDATE Settings SET value='3.4.4' WHERE name='system/platform/version';
UPDATE Settings SET value='1' WHERE name='system/platform/subVersion';
