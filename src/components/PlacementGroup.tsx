import React from 'react'
import styles from './PlacementGroup.module.css'

type Props = {
  title?: string
  note?: string
}

export default function PlacementGroup({ title = 'Placement Group', note }: Props) {
  return (
    <section className={styles.wrapper} aria-label={title}>
      <div className={styles.header}>
        <h3>{title}</h3>
        {note && <p className={styles.note}>{note}</p>}
      </div>
      <div className={styles.boxes}>
        <div className={styles.box}>Placeholder A</div>
        <div className={styles.box}>Placeholder B</div>
        <div className={styles.box}>Placeholder C</div>
      </div>
    </section>
  )
}
