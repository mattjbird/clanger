// Here are some test programs for testing

public final class TestPrograms {

    // 'Valid' programs (i.e., they would compile)
    public final class Valid {
        public static let return0 = """
            int main() {
                return 0;
            }
        """

        public static let return360 = """
            int main() {
                return 360;
            }
        """

        public static let newlines = """
            int
            main
            (
            )
            {
            return
            42
            ;
            }
        """

        public static let cramped = "int main(){return 42}"

        public static let spaces = "int main       (              )       {       return        42          ;         }"
    }

    // 'Invalid' programs (i.e., they would not compile)
    public final class Invalid {
        public static let missingClosingParen = """
            int main( {
                return 0;
            }
        """

        public static let missingReturnValue = """
            int main() {
                return;
            }
        """

        public static let missingClosingBrace = """
            int main() {
                return 0;
        """ 

        public static let missingSemiColon = """
            int main() {
                return 0
            }
        """

        public static let missingSpaceBetweenReturnAndReturned = """
            int main() {
                return0;
            }
        """

        public static let shouty = """
            INT MAIN() {
                RETURN 0;
            }
        """
    }
}