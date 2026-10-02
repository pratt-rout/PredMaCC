import { useEffect, useState } from 'react'

export default function App() {
  const [hello, setHello] = useState('')
  const [echoInput, setEchoInput] = useState('')
  const [echoResult, setEchoResult] = useState('')

  useEffect(() => {
    fetch('/api/hello')
      .then((res) => res.json())
      .then((data) => setHello(data.message))
      .catch(() => setHello('Failed to reach API'))
  }, [])

  async function sendEcho() {
    const res = await fetch('/api/echo', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: echoInput })
    })
    const data = await res.json()
    setEchoResult(data.echo)
  }

  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>PredMaCC</h1>
      <p>Backend says: {hello}</p>
      <input
        value={echoInput}
        onChange={(e) => setEchoInput(e.target.value)}
        placeholder="Type a message"
      />
      <button onClick={sendEcho}>Echo</button>
      {echoResult && <p>Echo response: {echoResult}</p>}
    </div>
  )
}
