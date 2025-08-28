"use client"
import React, {useState} from 'react'

export default function ContactForm(){
  const [status, setStatus] = useState<string | null>(null)
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setStatus('sending')
    // stub: simulate send
    await new Promise(r=>setTimeout(r,600))
    setStatus('sent')
  }
  return (
    <form onSubmit={handleSubmit} style={{marginTop:18}}>
      <div style={{display:'grid', gap:12}}>
        <input name="name" placeholder="Name" style={{padding:10,borderRadius:6,border:'1px solid #ddd'}} />
        <input name="email" placeholder="Email" style={{padding:10,borderRadius:6,border:'1px solid #ddd'}} />
        <textarea name="message" placeholder="Message" rows={6} style={{padding:10,borderRadius:6,border:'1px solid #ddd'}} />
        <div>
          <button type="submit" style={{padding:'10px 16px',borderRadius:6,background:'#0a8',color:'#fff',border:'none'}}>Send</button>
        </div>
        {status === 'sending' && <div>Sending…</div>}
        {status === 'sent' && <div>Message sent (stub)</div>}
      </div>
    </form>
  )
}
