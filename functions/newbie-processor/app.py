import json
from appwrite.client import Client
from appwrite.permission import Permission
from appwrite.role import Role
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

        rawPayload = req.variables.get('APPWRITE_FUNCTION_EVENT_DATA', None)
        secretsCol = req.variables.get('SECRETS_COL_ID', None)
        profilesCol = req.variables.get('PROFILES_COL_ID', None)
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
        elif not profilesCol:
            print(f'[!] Dammn! Missing parameters PROFILES_COL_ID ...')
            return res.json({
                'message': 'Missing parameters!',
                'success': False,
                'payload': rawPayload,
            })

        # Get processed payload
        payload = json.loads(rawPayload)

        try:
            # Setup secure user secrets storage (document security protected)
            database.create_document(
                database_id=payload['$databaseId'], collection_id=secretsCol,
                document_id=payload["$id"],
                data={
                    'contacts': [], 
                    'conversations': [], 
                }, 
                permissions=[
                    Permission.read(Role.user(payload["userId"])), # Add read for user
                    Permission.update(Role.user(payload["userId"])), # Add update for user
                ],
            )

            # Report on execution status
            return res.json({
                "success": True,
                "message": f'Completed setup for {payload["name"]} (@{payload["$id"]})',
            })
        except BaseException as e:
            # Report execution error status
            return res.json({
                'message': str(e),
                'success': False,
                'request': str(payload),
            })
