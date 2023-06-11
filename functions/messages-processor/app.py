import json
import re
import pytz

from dateutil.parser import parse
from datetime import datetime, timedelta

from appwrite.client import Client
from appwrite.id import ID
from appwrite.services.databases import Databases


def processUser(dUsername, database, payload, profilesCol, notificationsCol, dGroup=None):
    # Single user processing... get profile
    dProfile = database.get_document(
        database_id=payload['$databaseId'], collection_id=profilesCol,
        document_id=dUsername)

    # Check if not online
    if parse(dProfile['lastOnline']) < (datetime.utcnow() - timedelta(seconds=120)).replace(tzinfo=pytz.UTC):
        # Create notification
        if not dGroup:
            database.create_document(
                database_id=payload['$databaseId'], collection_id=notificationsCol,
                document_id=ID.unique(),
                data={
                    'title': f'{dProfile["name"]} (@{payload["entitiesId"]}) sent message',
                    'body': json.dumps({'msg': payload["text"], 'img': dProfile['avatar']}),
                    'sourceId': payload['sourceId'],
                    'destinationId': dUsername,
                }
            )
        else:
            database.create_document(
                database_id=payload['$databaseId'], collection_id=notificationsCol,
                document_id=ID.unique(),
                data={
                    'title': f'{dProfile["name"]} (@{dUsername}) posted in {dGroup["name"]}',
                    'body': json.dumps({'msg': payload["text"], 'img': dGroup['logo']}),
                    'sourceId': payload['sourceId'],
                    'destinationId': dUsername,
                }
            )

        print(f'[!] {dProfile["name"]} was offline... sent notification')


def main(req, res):
    # Init client
    client = Client()

    # Init database
    database = Databases(client)

    if not req.variables.get('HT_FUNCTION_ENDPOINT') or not req.variables.get('HT_FUNCTION_API_KEY'):
        print('Environment variables are not set. Function cannot use Appwrite SDK.')
    else:
        (
            client
            .set_endpoint(req.variables.get('HT_FUNCTION_ENDPOINT', None))
            .set_project(req.variables.get('APPWRITE_FUNCTION_PROJECT_ID', None))
            .set_key(req.variables.get('HT_FUNCTION_API_KEY', None))
            .set_self_signed(True)
        )

        rawPayload = req.variables.get('APPWRITE_FUNCTION_EVENT_DATA', None)
        notificationsCol = req.variables.get('NOTIFICATIONS_COL_ID', None)
        profilesCol = req.variables.get('PROFILES_COL_ID', None)
        groupsCol = req.variables.get('GROUPS_COL_ID', None)
        atlasCol = req.variables.get('ATLAS_COL_ID', None)
        if not rawPayload:
            print(f'[!] Dammn! Missing payload ...')
            return res.json({
                'message': 'Missing payload!',
                'success': False,
                'payload': rawPayload,
            })
        for col, colName in [(notificationsCol, 'NOTIFICATIONS'), (profilesCol, 'PROFILES'), (atlasCol, 'ATLAS'), (groupsCol, 'GROUPS')]:
            if not col:
                print(
                    f'[!] Dammn! Missing parameters {colName}_COL_ID ...')
                return res.json({
                    'message': 'Missing parameters!',
                    'success': False,
                    'payload': rawPayload,
                })

        # Get processed payload
        payload = json.loads(rawPayload)

        try:
            # Extract tags
            tags = []
            for word in payload['text'].split(' '):
                if word.startswith('#'):
                    # Extract word tags only
                    tags.append(" ".join(re.findall("[a-zA-Z]+", word)))

            print(f'[+] Found {len(tags)} tags')

            # Update feed with extracted tags
            database.update_document(
                database_id=payload['$databaseId'], collection_id=payload['$collectionId'],
                document_id=payload['$id'], data={'tags': tags}
            )

            if payload['toGroup']:
                # Group processing... get group details
                dGroup = database.get_document(
                    database_id=payload['$databaseId'], collection_id=groupsCol,
                    document_id=payload['entitiesId'])

                # Notify offline users
                for gUser in dGroup['dstEntities']:
                    processUser(gUser, database, payload, profilesCol, notificationsCol, dGroup)

                # Atlas indexing for groups
                for tag in tags:
                    try:
                        # Get current tag entry
                        aTag = database.get_document(
                            database_id=payload['$databaseId'], collection_id=atlasCol,
                            document_id=tag)
                        
                        if payload['entitiesId'] not in aTag['entities']:
                            newEntities = aTag['entities'] + [payload['entitiesId']]

                            # Update tag
                            database.update_document(
                                database_id=payload['$databaseId'], collection_id=atlasCol,
                                document_id=tag, data={'entities': newEntities}
                            )
                    except Exception:
                        # Tag doesn't exist
                        database.create_document(
                            database_id=payload['$databaseId'], collection_id=atlasCol,
                            document_id=tag,
                            data={'entities': [payload['entitiesId']]}
                        )
            else:
                processUser(payload['entitiesId'], database, payload, profilesCol, notificationsCol)
            return res.json({
                "success": True,
                "message": "Completed successfully",
            })
        except BaseException as e:
            return res.json({
                'message': str(e),
                'success': False,
                'request': str(payload),
            })
