export const metadata = { title: 'Home — Digital PIN' };

export default function HomeLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'Inter, Arial, sans-serif' }}>{children}</body>
    </html>
  );
}
