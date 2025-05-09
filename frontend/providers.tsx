"use client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { WagmiProvider } from "wagmi";
import { RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { baseSepolia } from "wagmi/chains"; // Changed from celoAlfajores
import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { http } from "wagmi";
import "@rainbow-me/rainbowkit/styles.css";

const config = getDefaultConfig({
  appName: process.env.NEXT_PUBLIC_APP_NAME || "PetTrace",
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || "",
  chains: [baseSepolia], // Changed to Base Sepolia
  transports: {
    [baseSepolia.id]: http(), // Changed to Base Sepolia
  },
  ssr: true, // Recommended for Next.js
});

const queryClient = new QueryClient();

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>{children}</RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
