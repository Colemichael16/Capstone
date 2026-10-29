// What the student sees on the lock screen, assembled live as the dispatcher types
export default function NotificationPreview({ headline, shortMessage }) {
  return (
    <div className="phone" aria-label="Notification preview">
      <div className="phone-clock">9:41</div>
      <div className="notification">
        <div className="notification-head">
          <span className="notification-icon" aria-hidden="true">!</span>
          <span>CAMPUS ALERT</span>
          <span className="notification-time">now</span>
        </div>
        <div className={`notification-title ${headline ? '' : 'placeholder'}`}>{headline || 'Headline'}</div>
        <div className={`notification-body ${shortMessage ? '' : 'placeholder'}`}>
          {shortMessage || 'Short message students will read first.'}
        </div>
      </div>
    </div>
  )
}
