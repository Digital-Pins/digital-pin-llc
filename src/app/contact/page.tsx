export const metadata = {
  title: 'Contact — Digital PIN',
  description: 'Get in touch with Digital PIN',
};

export default function ContactPage() {
  return (
    <main style={{fontFamily: 'Inter, Arial, sans-serif', padding: 24}}>
      <section style={{maxWidth: 1100, margin: '0 auto'}}>
        <header style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 20}}>
          <div>
            <h1 style={{margin: 0, fontSize: 36}}>Get in Touch</h1>
            <p style={{marginTop: 8, color: '#556'}}>Let&apos;s build your digital bridge together.</p>
          </div>
          <div style={{width: 260, height: 120, background: '#fff', borderRadius: 8, boxShadow: '0 6px 14px rgba(0,0,0,0.06)'}} />
        </header>

        <div style={{display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 20, marginTop: 36}}>
          <div style={{background: '#fff', padding: 20, borderRadius: 10, boxShadow: '0 6px 14px rgba(0,0,0,0.04)'}}>
            <h3 style={{marginTop: 0}}>Email</h3>
            <p style={{margin: 0, color: '#666'}}>ceo@4egtrust.com</p>
            <a href="mailto:ceo@4egtrust.com" style={{display: 'inline-block', marginTop: 12}}>Send Email</a>
          </div>
          <div style={{background: '#fff', padding: 20, borderRadius: 10, boxShadow: '0 6px 14px rgba(0,0,0,0.04)'}}>
            <h3 style={{marginTop: 0}}>Phone</h3>
            <p style={{margin: 0, color: '#666'}}>Mobile: +20 1X-XXX-XXXX<br/>Landline: 02-XXXX-XXXX</p>
          </div>
          <div style={{background: '#fff', padding: 20, borderRadius: 10, boxShadow: '0 6px 14px rgba(0,0,0,0.04)'}}>
            <h3 style={{marginTop: 0}}>Office Address</h3>
            <p style={{margin: 0, color: '#666'}}>Official office address here, Cairo, Egypt</p>
          </div>
        </div>

        <section style={{marginTop: 48, display: 'grid', gridTemplateColumns: '1fr 420px', gap: 30}}>
          <div>
            <h2>Contact Form</h2>
            <p style={{color: '#556'}}>Let&apos;s discuss your next project. Whether it&apos;s digital or engineering, we&apos;re here to bridge your needs with reliable solutions.</p>
            <form action="#" method="post" style={{marginTop: 18}}>
              <div style={{display: 'grid', gap: 12}}>
                <input name="name" placeholder="Name" style={{padding: 10, borderRadius: 6, border: '1px solid #ddd'}} />
                <input name="email" placeholder="Email" style={{padding: 10, borderRadius: 6, border: '1px solid #ddd'}} />
                <textarea name="message" placeholder="Message" rows={6} style={{padding: 10, borderRadius: 6, border: '1px solid #ddd'}} />
                <button type="submit" style={{padding: '10px 16px', borderRadius: 6, background: '#0a8', color: '#fff', border: 'none'}}>Send</button>
              </div>
            </form>
          </div>

          <aside style={{background: '#fff', padding: 20, borderRadius: 10, boxShadow: '0 6px 14px rgba(0,0,0,0.04)'}}>
            <h3>Office Hours</h3>
            <p style={{margin: 0, color: '#666'}}>Mon - Fri: 9:00 - 17:00</p>
            <div style={{height: 18}} />
            <h3>Social</h3>
            <p style={{margin: 0, color: '#666'}}>Twitter / LinkedIn / GitHub</p>
          </aside>
        </section>
      </section>
    </main>
  );
}
