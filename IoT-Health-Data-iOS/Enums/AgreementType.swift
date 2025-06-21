enum AgreementType: Identifiable {
    case privacyPolicy, termsOfService, healthData, locationData

    var id: Int { hashValue }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        case .healthData: return "Health Data Consent"
        case .locationData: return "Location Data Terms"
        }
    }

    var content: String {
        switch self {
        case .privacyPolicy: 
            return """
                'Health data app' values your privacy and is committed to handling your personal information in accordance with applicable laws. This privacy policy outlines what information we collect, how it is used, how long it is retained, and what measures are in place to protect it.

                1. Information We Collect  
                The app may collect the following information:  
                - Health Data: Steps, heart rate, blood oxygen levels, sleep analysis, calorie consumption, etc. (Collected via Apple HealthKit)  
                - Location Data: User’s current location (latitude and longitude)  
                - Login Information: User identifiers received via Apple Sign-In (e.g., email)  
                - Device Information: Logs and metadata generated during app use  

                2. Purpose of Collection and Use  
                The collected data is used solely for the following purposes:  
                - To analyze and visualize your health data and provide reports  
                - To offer location-based features (e.g., health insights based on your location)  
                - To improve user experience and enhance app performance  
                - For statistical analysis and customer support  

                3. Data Retention and Protection  
                Collected data is securely stored in encrypted form and retained only for the duration specified by law.  
                Data is transmitted using HTTPS and external access is strictly controlled.  
                Your data will never be sold or shared with third parties without your consent.  

                4. Third-Party Sharing  
                Your information is not shared with third parties unless:  
                - Required by law or legal process  
                - Explicit prior consent is obtained from the user  
                - Shared in anonymized form for research or statistical purposes  

                5. Your Rights  
                You may exercise the following rights at any time:  
                - Request to view or receive a copy of your data  
                - Request correction or deletion of data  
                - Withdraw consent for data collection and use  
                - Delete your account and permanently remove all data  
                (These requests can be made through the app settings or by contacting us)  

                6. HealthKit Data Notice  
                This app uses Apple’s HealthKit framework. All data collected via HealthKit is used strictly for providing services within the app.  
                It is never used for marketing or advertising purposes, nor shared with third parties without explicit consent.  

                7. Location Data Notice  
                The app may access your location data to provide contextual health analysis.  
                Location data is used in real-time only and is not stored or shared.  

                8. Contact Information
                For any questions regarding this privacy policy, please contact:  
                Privacy Officer: [NAME]
                Email: [EMAIL]
                """
            
        case .termsOfService: return "여기에 Terms of Service 자세한 내용을 작성하세요..."
        case .healthData: return "여기에 Health Data Consent 자세한 내용을 작성하세요..."
        case .locationData: return "여기에 Location Data Terms 자세한 내용을 작성하세요..."
        }
    }
}
