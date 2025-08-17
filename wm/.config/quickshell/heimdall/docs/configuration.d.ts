// Auto-generated TypeScript definitions for Heimdall configuration

export interface HeimdallConfig {
  version: string;
  meta?: {
    profile?: string;
    created?: string;
    modified?: string;
  };
  modules?: {
    appearance?: AppearanceConfig;
    general?: GeneralConfig;
    background?: BackgroundConfig;
    bar?: BarConfig;
    border?: BorderConfig;
    dashboard?: DashboardConfig;
    controlCenter?: ControlcenterConfig;
    launcher?: LauncherConfig;
    notifications?: NotificationsConfig;
    osd?: OsdConfig;
    session?: SessionConfig;
    lock?: LockConfig;
    uiComponents?: UicomponentsConfig;
    animation?: AnimationConfig;
    servicesIntegration?: ServicesintegrationConfig;
    behavior?: BehaviorConfig;
  };
}
