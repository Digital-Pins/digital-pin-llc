export const metadata = {
  title: 'Digital PIN',
  description: 'Digital PIN Dev Hub',
};

export default function HomePage() {
  return (
    <main style={{fontFamily: 'Inter, Arial, sans-serif', padding: 24}}>
      <section style={{maxWidth: 1100, margin: '0 auto'}}>
        <h1 style={{fontSize: 40}}>Digital PIN Dev Hub</h1>
        <p style={{color: '#556'}}>Central place for dev demos, infra, and services.</p>
        <div style={{marginTop: 24}}>
          <a href="/contact" style={{color: '#0a8'}}>Contact</a>
        </div>
      </section>
    </main>
  );
}
