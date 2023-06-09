import json
from appwrite.client import Client
from appwrite.query import Query
from appwrite.services.databases import Databases


def main(req, res):
    # init client
    client = Client()

    # init database
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

        rawPayload = req.variables.get('APPWRITE_FUNCTION_DATA', None)
        secretsCol = req.variables.get('SECRETS_COL_ID', None)
        databaseId = req.variables.get('DATABASE_ID', None)
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
        elif not databaseId:
            print(f'[!] Dammn! Missing parameters DATABASE_ID ...')
            return res.json({
                'message': 'Missing parameters!',
                'success': False,
                'payload': rawPayload,
            })

        # Get processed payload
        payload = json.loads(rawPayload)

        try:
            # Get username1 secrets
            secrets1 = database.get_document(
                    database_id=databaseId, collection_id=secretsCol, 
                    document_id=payload["username1"])

            # Get username2 secrets
            secrets2 = database.get_document(
                    database_id=databaseId, collection_id=secretsCol, 
                    document_id=payload["username2"])

            # Read conversations
            conversations1 = secrets1['conversations']
            conversations2 = secrets2['conversations']

            # Update contacts
            if payload["username2"] not in conversations1:
                conversations1.append(payload["username2"])
            
            if payload["username1"] not in conversations2:
                conversations2.append(payload["username1"])

            # Add username1 to username2 conversations
            database.update_document(
                    database_id=databaseId, collection_id=secretsCol, 
                    document_id=payload["username1"], data={'conversations': conversations1})

            # Add username2 to username1 conversations
            database.update_document(
                    database_id=databaseId, collection_id=secretsCol, 
                    document_id=payload["username2"], data={'conversations': conversations2})

            # Report on execution status
            return res.json({
                "success": True,
                "message": f'Successfully started conversation between @{payload["username1"]} and @{payload["username2"]}',
            })
        except BaseException as e:
            # Report execution error status
            return res.json({
                'message': str(e),
                'success': False,
                'request': str(payload),
            })
