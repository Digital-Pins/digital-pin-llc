import React from 'react'
import styles from './PlatformHero.module.css'

export default function PlatformHero() {
  return (
    <section className={styles.wrapper} aria-label="Platform hero">
      <div className={styles.card}>
        <div className={styles.visual}>
          <div className={styles.boxes}>
            <div className={styles.box} data-pos="left" />
            <div className={styles.box} data-pos="center" />
            <div className={styles.box} data-pos="right" />
          </div>

          <svg className={styles.svg} viewBox="0 0 520 200" aria-hidden="true">
            <defs>
              <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stopColor="#E8C76B" />
                <stop offset="100%" stopColor="#D4AF37" />
              </linearGradient>
            </defs>
            <g stroke="#0B1F3A" strokeWidth="3" fill="none" strokeLinecap="round" strokeLinejoin="round" opacity=".9">
              <line x1="60" y1="140" x2="60" y2="170" />
              <line x1="460" y1="140" x2="460" y2="170" />
              <line x1="40" y1="140" x2="480" y2="140" />
              <path d="M40 140 Q 260 40 480 140" />
            </g>
            <g className={styles.dots} fill="url(#g)">
              <circle className={styles.dot} cx="200" cy="100" r="4" />
              <circle className={styles['dot--alt']} cx="260" cy="80" r="4" />
              <circle className={styles.dot} cx="320" cy="100" r="4" />
            </g>
            <rect x="88" y="70" width="90" height="60" rx="8" fill="#ECF0F1" stroke="#2C3E50" />
            <rect x="210" y="50" width="100" height="80" rx="10" fill="#ECF0F1" stroke="#2C3E50" />
            <rect x="334" y="62" width="76" height="68" rx="8" fill="#ECF0F1" stroke="#2C3E50" />
            <g fill="none" stroke="#2C3E50" opacity=".7">
              <path d="M320 40c6-12 18-18 30-16 10-16 36-12 44 4 16-2 28 10 28 22 0 14-12 24-26 24h-72c-10 0-18-8-18-18 0-8 6-14 14-16Z" />
            </g>
          </svg>

          <div className={styles.platform} />
        </div>
      </div>
    </section>
  )
}
