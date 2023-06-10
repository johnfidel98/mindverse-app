import json
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def main(req, res):
    rawPayload = req.variables.get('APPWRITE_FUNCTION_DATA', None)
    if not rawPayload:
        print(f'[!] Dammn! Missing payload ...')
        return res.json({
            'message': 'Missing payload!',
            'success': False,
            'payload': rawPayload,
        })

    # Get processed payload
    payload = json.loads(rawPayload)

    try:
        content = f'''
Hey you ...\n
\n
\n{payload["client"]} invited you to to join us at MindVerse. You can download the app from the link below!
\n
\ntodo: https://huawei
\n
\n
\nMindVerse Team
\nThanks
        '''

        # Create message container
        msg = MIMEMultipart('alternative')
        msg['Subject'] = f'[MindVerse] {payload["client"]} invited you!'
        msg['From'] = req.variables.get('G_USER')
        msg['To'] = payload['invitee_email']

        # Attach plain text and HTML content to the message
        plain_text = MIMEText(content, 'plain')
        html_text = MIMEText(content, 'html')
        msg.attach(plain_text)
        msg.attach(html_text)

        # Connect to the SMTP server
        smtp_server = 'smtp.gmail.com'  # Change if using a different email provider
        smtp_port = 587  # Change if using a different email provider
        smtp_connection = smtplib.SMTP(smtp_server, smtp_port)
        smtp_connection.starttls()

        # Login to the Google account
        smtp_connection.login(req.variables.get('G_USER'), req.variables.get('G_PASS'))

        # Send the email
        smtp_connection.sendmail(req.variables.get('G_USER'), payload['invitee_email'], msg.as_string())

        # Close the connection
        smtp_connection.quit()

        # Report on execution status
        return res.json({
            "success": True,
            "message": f'Successfully sent invite to {payload["invitee_email"]} ...',
        })
    except BaseException as e:
        # Report execution error status
        return res.json({
            'message': str(e),
            'success': False,
            'request': str(payload),
        })
