import React from 'react'
import PlacementGroup from '../components/PlacementGroup'
import PlatformHero from '../components/PlatformHero'

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

      <div style={{maxWidth: 1100, margin: '2rem auto'}}>
        <PlatformHero />
      </div>

      <div style={{maxWidth: 1100, margin: '2rem auto'}}>
        <PlacementGroup title="Placement Group" note="Add content blocks here" />
      </div>
    </main>
  )
}
