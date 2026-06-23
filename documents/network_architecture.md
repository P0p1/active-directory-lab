# VMware Lab Network Architecture

This document outlines the software-defined networking topology used to isolate the Active Directory environment while maintaining secure external transit capabilities.

## 🗺️ Visual Topology & Mappings

```text
[ Physical Host (Internet) ]
             │
             ▼ (VMware NAT Engine)
┌────────────────────────────────────────┐
│ Virtual Router / Gateway: 192.168.83.2 │
└────────────────────┬───────────────────┘
                     │
         ┌───────────┴───────────┐
         ▼ (VMnet8 Private Bus)  ▼
┌────────────────────────┐   ┌────────────────────────┐
│ Domain Controller      │   │ Workstation Client     │
│ Name: Serve01          │   │ Name: ClientWin11      │
│ IP: 192.168.83.10      │   │ IP: 192.168.83.20      │
│ DNS: 127.0.0.1         │   │ DNS: 192.168.83.10     │
└────────────────────────┘   └────────────────────────┘
```

## ⚙️ Network Interface Configuration Specifications

### 1. Host Machine Allocation (`VMnet8 Interface`)

- **Host Internal IP:** `192.168.83.1`
- **Subnet Mask:** `255.255.255.0`

### 2. Domain Controller (`Serve01.ecorp.co.za`)

- **Static IPv4 Allocation:** `192.168.83.10`
- **Subnet Mask:** `255.255.255.0`
- **Default Gateway:** `192.168.83.2` _(VMware NAT Router Routing Endpoint)_
- **Primary Loopback DNS:** `127.0.0.1` _(Mandatory for Active Directory DS locator service operations)_
- **Upstream Forwarder Target:** `192.168.83.2` (or `8.8.8.8`) configured directly within the Windows DNS MMC snap-in to safely resolve external WAN zones.

### 3. Client Workstation

- **Static IPv4 Allocation:** `192.168.83.20`
- **Subnet Mask:** `255.255.255.0`
- **Default Gateway:** `192.168.83.2`
- **Primary Domain DNS:** `192.168.83.10` _(Points directly to DC for secure Kerberos realm ticket issuance)_
