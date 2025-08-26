export const metadata = {
  title: 'About — Digital PIN',
  description: 'About Digital PIN Dev Hub',
};

export default function AboutPage() {
  return (
    <main style={{fontFamily: 'Inter, Arial, sans-serif', padding: 24}}>
      <section style={{maxWidth: 900, margin: '0 auto'}}>
        <h1>About Digital PIN</h1>
        <p style={{color: '#556'}}>Digital PIN Dev Hub — integration point for ERP, Edu, and AI services.</p>
        <h2 style={{marginTop: 28}}>Purpose</h2>
        <p style={{color: '#666'}}>This repo is the development hub: infra scripts, deployment templates, and demo stacks for Digital PIN services.</p>
      </section>
    </main>
  );
}
