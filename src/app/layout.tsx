import './globals.css'
import type { Metadata } from 'next'
import { Geist, Geist_Mono } from 'next/font/google'
import React from 'react'
import Link from 'next/link'

const geistSans = Geist({ variable: '--font-geist-sans', subsets: ['latin'] })
const geistMono = Geist_Mono({ variable: '--font-geist-mono', subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Digital PIN',
  description: 'Site snapshot rebuild',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
        <header className="site-header">
          import './globals.css'
          import type { Metadata } from 'next'
          import { Geist, Geist_Mono } from 'next/font/google'
          import React from 'react'
          import Link from 'next/link'
          
          const geistSans = Geist({ variable: '--font-geist-sans', subsets: ['latin'] })
          const geistMono = Geist_Mono({ variable: '--font-geist-mono', subsets: ['latin'] })
          
          export const metadata: Metadata = {
            title: 'Digital PIN',
            description: 'Site snapshot rebuild',
          }
          
          export default function RootLayout({ children }: { children: React.ReactNode }) {
            return (
              <html lang="en">
                <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
                  <header className="site-header">
                    <div className="container">
                      <Link className="brand" href="/">Digital PIN</Link>
                      <nav className="nav">
                        <Link href="/about">About</Link>
                        <Link href="/projects">Projects</Link>
                        <Link href="/service">Service</Link>
                        <Link href="/contact">Contact</Link>
                      </nav>
                    </div>
                  </header>
                  <main className="container">{children}</main>
                  <footer className="site-footer">
                    <div className="container">© Digital PIN</div>
                  </footer>
                </body>
              </html>
            )
          }
            <Link className="brand" href="/">Digital PIN</Link>
            <nav className="nav">
              <Link href="/about">About</Link>
              <Link href="/projects">Projects</Link>
              <Link href="/service">Service</Link>
              <Link href="/contact">Contact</Link>
            </nav>
          </div>
        </header>
        <main className="container">{children}</main>
        <footer className="site-footer">
          <div className="container">© Digital PIN</div>
        </footer>
      </body>
    </html>
  )
}
