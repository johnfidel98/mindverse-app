import json
from appwrite.client import Client
from appwrite.query import Query
from appwrite.services.databases import Databases
from appwrite.services.users import Users


def main(req, res):
    # init client
    client = Client()

    # init database
    database = Databases(client)

    # init users
    users = Users(client)

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
        secretsCol = req.variables.get('SECRETS_COL_ID', None)
        if not rawPayload:
            print(f'[!] Dammn! Missing payload ...')
            return res.json({
                'message': 'Missing payload!',
                'success': False,
                'payload': rawPayload,
            })
        elif not secretsCol:
            print(f'[!] Dammn! Missing parameters SECRETS_COL_ID ...')
            return res.json({
                'message': 'Missing parameters!',
                'success': False,
                'payload': rawPayload,
            })

        # Get processed payload
        payload = json.loads(rawPayload)

        try:
            contacts = []
            state = 'Processed'
            for rawC in payload['contacts']:
                contact = json.loads(rawC)

                # Check contacts for any unprocessed item
                if contact['s'] != 1:
                    # Process unprocessed items
                    newC = {'s': 0, 'e': contact['e'], 'u': ''}

                    # Check if email exists in the system
                    try:
                        # Check for user
                        users_list = users.list(queries=[Query.equal('email', [contact['e']])])

                        if users_list['total'] != 1:
                            # Future : Report malicious
                            pass

                        # Get username in prefs
                        newC['s'] = 1
                        newC['u'] = users_list['users'][0]['prefs']['username']
                        
                        state = 'Updated'
                    except Exception:
                        # Set timestamp for next update check
                        pass

                    # Apply changes necessary
                    contacts.append(json.dumps(newC))
                else:
                    # No changes necessary
                    contacts.append(rawC)

            # Update contacts
            database.update_document(
                    database_id=payload['$databaseId'], collection_id=secretsCol, 
                    document_id=payload["$id"], data={'contacts': contacts})

            # Report on execution status
            return res.json({
                "success": True,
                "message": f'{state} contacts for @{payload["$id"]}',
            })
        except BaseException as e:
            # Report execution error status
            return res.json({
                'message': str(e),
                'success': False,
                'request': str(payload),
            })
