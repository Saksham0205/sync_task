const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Email configuration
const gmailEmail = 'ajnabeecorp@gmail.com';
const gmailPassword = 'gowg xwlf ewmv awjv';

// Create reusable transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword
  }
});

// Helper function to send email
async function sendEmail(to, subject, htmlContent, textContent) {
  const mailOptions = {
    from: `SyncTask <${gmailEmail}>`,
    to: to,
    subject: subject,
    text: textContent,
    html: htmlContent
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
}

// Email templates
const emailTemplates = {
  friendRequest: (senderUsername, receiverUsername) => ({
    subject: '🤝 New Friend Request from ' + senderUsername,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
          <h1 style="color: #2196F3; margin-bottom: 20px;">👋 New Friend Request!</h1>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Hi <strong>${receiverUsername}</strong>,
          </p>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            <strong>${senderUsername}</strong> has sent you a friend request on SyncTask!
          </p>
          <div style="background-color: #E3F2FD; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <p style="margin: 0; color: #1976D2; font-size: 14px;">
              Open the SyncTask app to accept or decline this request and start collaborating on tasks together!
            </p>
          </div>
          <p style="font-size: 14px; color: #666; margin-top: 30px;">
            Best regards,<br>
            <strong>The SyncTask Team</strong>
          </p>
        </div>
        <p style="text-align: center; color: #999; font-size: 12px; margin-top: 20px;">
          This is an automated message from SyncTask. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `Hi ${receiverUsername},\n\n${senderUsername} has sent you a friend request on SyncTask!\n\nOpen the SyncTask app to accept or decline this request and start collaborating on tasks together!\n\nBest regards,\nThe SyncTask Team`
  }),

  friendRequestAccepted: (accepterUsername, senderUsername) => ({
    subject: '✅ Friend Request Accepted by ' + accepterUsername,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
          <h1 style="color: #4CAF50; margin-bottom: 20px;">🎉 Friend Request Accepted!</h1>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Hi <strong>${senderUsername}</strong>,
          </p>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Great news! <strong>${accepterUsername}</strong> has accepted your friend request on SyncTask!
          </p>
          <div style="background-color: #E8F5E9; border-left: 4px solid #4CAF50; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <p style="margin: 0; color: #2E7D32; font-size: 14px;">
              You can now create task groups and collaborate together. Start syncing your tasks today!
            </p>
          </div>
          <p style="font-size: 14px; color: #666; margin-top: 30px;">
            Best regards,<br>
            <strong>The SyncTask Team</strong>
          </p>
        </div>
        <p style="text-align: center; color: #999; font-size: 12px; margin-top: 20px;">
          This is an automated message from SyncTask. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `Hi ${senderUsername},\n\nGreat news! ${accepterUsername} has accepted your friend request on SyncTask!\n\nYou can now create task groups and collaborate together. Start syncing your tasks today!\n\nBest regards,\nThe SyncTask Team`
  }),

  groupInvitation: (inviterUsername, groupName, inviteeUsername) => ({
    subject: '📋 You\'ve been invited to join "' + groupName + '"',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
          <h1 style="color: #FF9800; margin-bottom: 20px;">📋 New Group Invitation!</h1>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Hi <strong>${inviteeUsername}</strong>,
          </p>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            <strong>${inviterUsername}</strong> has invited you to join the task group:
          </p>
          <div style="background-color: #FFF3E0; border-left: 4px solid #FF9800; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <h2 style="margin: 0 0 10px 0; color: #F57C00; font-size: 18px;">${groupName}</h2>
            <p style="margin: 0; color: #E65100; font-size: 14px;">
              Join this group to collaborate on shared tasks and track progress together!
            </p>
          </div>
          <p style="font-size: 14px; color: #666; margin-top: 30px;">
            Best regards,<br>
            <strong>The SyncTask Team</strong>
          </p>
        </div>
        <p style="text-align: center; color: #999; font-size: 12px; margin-top: 20px;">
          This is an automated message from SyncTask. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `Hi ${inviteeUsername},\n\n${inviterUsername} has invited you to join the task group: "${groupName}"\n\nJoin this group to collaborate on shared tasks and track progress together!\n\nBest regards,\nThe SyncTask Team`
  }),

  taskDeadlineReminder: (username, taskText, deadline, groupName = null) => ({
    subject: '⏰ Task Deadline Reminder: ' + taskText,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
          <h1 style="color: #F44336; margin-bottom: 20px;">⏰ Task Deadline Approaching!</h1>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Hi <strong>${username}</strong>,
          </p>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            This is a friendly reminder that your task deadline is approaching:
          </p>
          <div style="background-color: #FFEBEE; border-left: 4px solid #F44336; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <h2 style="margin: 0 0 10px 0; color: #C62828; font-size: 18px;">${taskText}</h2>
            <p style="margin: 5px 0; color: #B71C1C; font-size: 14px;">
              <strong>Deadline:</strong> ${deadline}
            </p>
            ${groupName ? `<p style="margin: 5px 0; color: #B71C1C; font-size: 14px;"><strong>Group:</strong> ${groupName}</p>` : ''}
          </div>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Don't forget to mark it as complete when you're done!
          </p>
          <p style="font-size: 14px; color: #666; margin-top: 30px;">
            Best regards,<br>
            <strong>The SyncTask Team</strong>
          </p>
        </div>
        <p style="text-align: center; color: #999; font-size: 12px; margin-top: 20px;">
          This is an automated message from SyncTask. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `Hi ${username},\n\nThis is a friendly reminder that your task deadline is approaching:\n\nTask: ${taskText}\nDeadline: ${deadline}${groupName ? `\nGroup: ${groupName}` : ''}\n\nDon't forget to mark it as complete when you're done!\n\nBest regards,\nThe SyncTask Team`
  }),

  welcomeEmail: (username, email) => ({
    subject: '🎉 Welcome to SyncTask!',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
        <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
          <h1 style="color: #2196F3; margin-bottom: 20px;">🎉 Welcome to SyncTask!</h1>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Hi <strong>${username}</strong>,
          </p>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Thank you for joining SyncTask! We're excited to help you stay organized and collaborate with friends on your daily tasks.
          </p>
          <div style="background-color: #E3F2FD; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <h3 style="margin: 0 0 10px 0; color: #1976D2; font-size: 16px;">Get Started:</h3>
            <ul style="margin: 0; padding-left: 20px; color: #1565C0; font-size: 14px;">
              <li>Create your first personal task</li>
              <li>Search for friends and send friend requests</li>
              <li>Create task groups to collaborate</li>
              <li>Track your progress together!</li>
            </ul>
          </div>
          <p style="font-size: 16px; color: #333; line-height: 1.6;">
            Your account has been successfully created with the email: <strong>${email}</strong>
          </p>
          <p style="font-size: 14px; color: #666; margin-top: 30px;">
            Best regards,<br>
            <strong>The SyncTask Team</strong>
          </p>
        </div>
        <p style="text-align: center; color: #999; font-size: 12px; margin-top: 20px;">
          This is an automated message from SyncTask. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `Hi ${username},\n\nThank you for joining SyncTask! We're excited to help you stay organized and collaborate with friends on your daily tasks.\n\nGet Started:\n- Create your first personal task\n- Search for friends and send friend requests\n- Create task groups to collaborate\n- Track your progress together!\n\nYour account has been successfully created with the email: ${email}\n\nBest regards,\nThe SyncTask Team`
  })
};

// Cloud Function: Send welcome email on user creation
exports.sendWelcomeEmail = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    const { username, email } = userData;

    if (!email) {
      console.log('No email found for user');
      return null;
    }

    const template = emailTemplates.welcomeEmail(username, email);
    
    try {
      await sendEmail(email, template.subject, template.html, template.text);
      console.log('Welcome email sent to:', email);
      return null;
    } catch (error) {
      console.error('Error sending welcome email:', error);
      return null;
    }
  });

// Cloud Function: Send email on friend request
exports.sendFriendRequestEmail = functions.firestore
  .document('friendRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const requestData = snap.data();
    const { senderUsername, receiverId } = requestData;

    try {
      // Get receiver's email
      const receiverDoc = await admin.firestore().collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) {
        console.log('Receiver user not found');
        return null;
      }

      const receiverData = receiverDoc.data();
      const receiverEmail = receiverData.email;
      const receiverUsername = receiverData.username;

      if (!receiverEmail) {
        console.log('No email found for receiver');
        return null;
      }

      const template = emailTemplates.friendRequest(senderUsername, receiverUsername);
      await sendEmail(receiverEmail, template.subject, template.html, template.text);
      console.log('Friend request email sent to:', receiverEmail);
      return null;
    } catch (error) {
      console.error('Error sending friend request email:', error);
      return null;
    }
  });

// Cloud Function: Send email when friend request is accepted
exports.sendFriendRequestAcceptedEmail = functions.firestore
  .document('friendRequests/{requestId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if status changed from pending to accepted
    if (beforeData.status === 'pending' && afterData.status === 'accepted') {
      const { senderId, senderUsername } = afterData;

      try {
        // Get sender's email
        const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
        if (!senderDoc.exists) {
          console.log('Sender user not found');
          return null;
        }

        const senderData = senderDoc.data();
        const senderEmail = senderData.email;

        if (!senderEmail) {
          console.log('No email found for sender');
          return null;
        }

        // Get accepter's username
        const receiverDoc = await admin.firestore().collection('users').doc(afterData.receiverId).get();
        const accepterUsername = receiverDoc.exists ? receiverDoc.data().username : 'Someone';

        const template = emailTemplates.friendRequestAccepted(accepterUsername, senderUsername);
        await sendEmail(senderEmail, template.subject, template.html, template.text);
        console.log('Friend request accepted email sent to:', senderEmail);
        return null;
      } catch (error) {
        console.error('Error sending friend request accepted email:', error);
        return null;
      }
    }
    return null;
  });

// Callable function: Send group invitation email
exports.sendGroupInvitationEmail = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { inviteeEmail, inviteeUsername, inviterUsername, groupName } = data;

  if (!inviteeEmail || !inviterUsername || !groupName) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  try {
    const template = emailTemplates.groupInvitation(inviterUsername, groupName, inviteeUsername);
    await sendEmail(inviteeEmail, template.subject, template.html, template.text);
    return { success: true, message: 'Group invitation email sent successfully' };
  } catch (error) {
    console.error('Error sending group invitation email:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send email');
  }
});

// Callable function: Send task deadline reminder email
exports.sendTaskDeadlineReminderEmail = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userEmail, username, taskText, deadline, groupName } = data;

  if (!userEmail || !username || !taskText || !deadline) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  try {
    const template = emailTemplates.taskDeadlineReminder(username, taskText, deadline, groupName);
    await sendEmail(userEmail, template.subject, template.html, template.text);
    return { success: true, message: 'Task deadline reminder email sent successfully' };
  } catch (error) {
    console.error('Error sending task deadline reminder email:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send email');
  }
});

