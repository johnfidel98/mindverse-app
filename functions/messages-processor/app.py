import json
import re
import pytz

from dateutil.parser import parse
from datetime import datetime, timedelta

from appwrite.client import Client
from appwrite.id import ID
from appwrite.services.databases import Databases


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
        if not rawPayload:
            print(f'[!] Dammn! Missing payload ...')
            return res.json({
                'message': 'Missing payload!',
                'success': False,
                'payload': rawPayload,
            })
        for col, colName in [(notificationsCol, 'NOTIFICATIONS'), (profilesCol, 'PROFILES')]:
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

            # Set notification task to be processed later
            if not payload['toGroup']:
                # Get profile
                dProfile = database.get_document(
                    database_id=payload['$databaseId'], collection_id=profilesCol,
                    document_id=payload['entitiesId'])

                # Check if not online
                if parse(dProfile['lastOnline']) < (datetime.utcnow() - timedelta(seconds=120)).replace(tzinfo=pytz.UTC):
                    # Create notification
                    database.create_document(
                        database_id=payload['$databaseId'], collection_id=notificationsCol,
                        document_id=ID.unique(),
                        data={
                            'title': f'{dProfile["name"]} (@{payload["entitiesId"]}) sent message',
                            'body': json.dumps({'msg': payload["text"], 'img': dProfile['avatar']}),
                            'sourceId': payload['sourceId'],
                            'destinationId': payload['entitiesId'],
                        }
                    )

                    print(f'[!] User offline... sent notification')
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
