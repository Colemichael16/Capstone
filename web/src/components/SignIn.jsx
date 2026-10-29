import { useState } from 'react'
import { supabase } from '../supabase.js'

// Dispatcher accounts are created in Supabase, not here (see db/README.md)
export default function SignIn() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const [pending, setPending] = useState(false)

  return (
    <form
      className="composer"
      onSubmit={async (e) => {
        e.preventDefault()
        setPending(true)
        setError(null)
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) setError(error.message)
        setPending(false)
      }}
    >
      <h2>Dispatcher sign in</h2>

      <label>
        Email
        <input type="email" required autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} />
      </label>

      <label>
        Password
        <input
          type="password"
          required
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </label>

      {error && (
        <p className="warning" role="alert">
          {error}
        </p>
      )}

      <button type="submit" disabled={pending}>
        {pending ? 'Signing in…' : 'Sign in'}
      </button>
    </form>
  )
}
